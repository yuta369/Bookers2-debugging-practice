class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book.increment!(:view_count)
    @book_comment = BookComment.new
    @user = @book.user
    @new_book = Book.new
  end

  def index
  @book = Book.new
  # @books = Book.all
  to = Time.current.at_end_of_day
  from = (to - 6.day).at_beginning_of_day
  @books = Book.includes(:favorites).
    sort_by{ |x|
      -x.favorites.where(created_at: from...to).count
     }
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "You have destroyed book successfully."
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
