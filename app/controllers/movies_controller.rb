class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end


  def get_ratings
    Movie.get_ratings
  end
  

  
  def index
    @all_ratings = Movie.get_ratings
    @saved_ratings = session["ratings"]
    
    if (!params["ratings"] and !(session["ratings"].any?))
     @chosen_ratings = @all_ratings
    elsif (!params["ratings"])
     @chosen_ratings =  Hash[@saved_ratings.map {|v| [v,1]}].keys
    else
     @chosen_ratings =  Hash(params["ratings"]).keys
    end
    
    
    if (params["title"])
      @movies = Movie.order(:title).where(:rating => @chosen_ratings)
      session["title"] = true
      params["release_date"] = false
      session["release_date"] = false
      session["ratings"] = @chosen_ratings
    elsif (params["release_date"])
      @movies = Movie.order(:release_date).where(:rating => @chosen_ratings)
      session["release_date"] = true
      params["title"] = false
      session["title"] = false
      session["ratings"] = @chosen_ratings
    elsif (session["title"])
      @movies = Movie.order(:title).where(:rating => @chosen_ratings)
      params["release_date"] = false
      session["release_date"] = false
      session["ratings"] = @chosen_ratings
    elsif (session["release_date"])
      @movies = Movie.order(:release_date).where(:rating => @chosen_ratings)
      params["title"] = false
      session["title"] = false
      session["ratings"] = @chosen_ratings
    else
      @movies = Movie.where(:rating => @chosen_ratings)
      session["ratings"] = @chosen_ratings
    end
    
  end

  def sort_by_title
      @movie_list = Movie.order(:title)
      @movie_list.where(:rating => @chosen_ratings).order(:title)
  end
  
  def sort_by_date
      @movie_list = Movie.order(:release_date)
      @movie_list.where(:rating => @chosen_ratings) 
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

end
