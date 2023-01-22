class WikiAnimalsController < ApplicationController
  before_action :set_wiki_animal, only: %i[ show edit update destroy ]

  # GET /wiki_animals
  def index
    @wiki_animals = WikiAnimal.all
  end

  # GET /wiki_animals/1
  def show
  end

  # GET /wiki_animals/new
  def new
    @wiki_animal = WikiAnimal.new
  end

  # GET /wiki_animals/1/edit
  def edit
  end

  # POST /wiki_animals
  def create
    @wiki_animal = WikiAnimal.new(wiki_animal_params)

    if @wiki_animal.save
      redirect_to @wiki_animal, notice: "Wiki animal was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /wiki_animals/1
  def update
    if @wiki_animal.update(wiki_animal_params)
      redirect_to @wiki_animal, notice: "Wiki animal was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /wiki_animals/1
  def destroy
    @wiki_animal.destroy
    redirect_to wiki_animals_url, notice: "Wiki animal was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wiki_animal
      @wiki_animal = WikiAnimal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wiki_animal_params
      params.require(:wiki_animal).permit(:name, :latin, :title, :wiki_url, :short_taxo, :wiki_description, :internal_description, :parse_version, :picture_url)
    end
end
