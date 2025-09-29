class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Step 1: handle ratings filter
    if params[:ratings].present?
      @ratings_to_show = params[:ratings].keys
    elsif session[:ratings].present?
      # if params missing but session has value, use session
      @ratings_to_show = session[:ratings].keys
      params[:ratings] = session[:ratings]
    else
      # default = show all ratings
      @ratings_to_show = Movie.all.pluck(:rating).uniq
    end
  
    # Step 2: handle sort_by
    if params[:sort_by].present?
      @sort_by = params[:sort_by]
    elsif session[:sort_by].present?
      @sort_by = session[:sort_by]
      params[:sort_by] = session[:sort_by]
    else
      @sort_by = nil
    end
  
    # Step 3: persist into session
    session[:ratings] = params[:ratings]
    session[:sort_by] = @sort_by
  
    # Step 4: fetch movies
    if @sort_by.present?
      @movies = Movie.where(rating: @ratings_to_show).order(@sort_by)
    else
      @movies = Movie.where(rating: @ratings_to_show)
    end
  
    # Step 5: for view checkboxes
    @all_ratings = Movie.all.pluck(:rating).uniq
  end
  
  
  
  
  

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
