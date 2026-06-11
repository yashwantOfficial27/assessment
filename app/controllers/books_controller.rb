class BooksController < ApplicationController
  def index
    cache_key = "books:index"

    # dynamic key building
    # params.slice(:author, :genre, :sort).to_h.sort.each do |key, value|
    #   cache_key += ":#{key}:#{value}" if ['author','genre','sort'].include?(key)
    # end

    params.slice(:author, :genre, :sort).permit!.to_h.sort.each do |key, value|
        cache_key += ":#{key}:#{value}"
    end

    cached_books = $redis.get(cache_key)

    if cached_books.present?
      render json: JSON.parse(cached_books) and return
    end

    # DB query
    @books = Book.all

    if params[:author].present?
      @books = @books.where(author: params[:author])
    elsif params[:genre].present?
      @books = @books.where(genre: params[:genre])
    end

    if params[:sort].present?
      case params[:sort]
      when 'rating'
        @books = @books.order(rating: :asc)
      when '-rating'
        @books = @books.order(rating: :desc)
      end
    end

    # write cache
    $redis.set(cache_key, @books.to_json, ex: 300)

    render json: @books, status: :ok
  end

def create
  @book = Book.new(book_params)

  if @book.save
    $redis.scan_each(match: "books:index*") { |key| $redis.del(key) }

    render json: @book, status: :created
  else
    render json: @book.errors, status: :unprocessable_entity
  end
end

def show
  cache_key = "books:show:#{params[:id]}"

  cached_book = $redis.get(cache_key)

  if cached_book.present?
    render json: JSON.parse(cached_book) and return
  end

  @book = Book.find_by(id: params[:id])

  if @book.present?
    $redis.set(cache_key, @book.to_json, ex: 300)
    render json: @book
  else
    render json: { error: "Not found" }, status: :not_found
  end
end

end