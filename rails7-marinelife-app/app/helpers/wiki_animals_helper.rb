module WikiAnimalsHelper
  def render_picture(animal)
      #:TODO
      return 'no image' unless animal.picture_url
      image_tag(animal.picture_url)
  end
end
