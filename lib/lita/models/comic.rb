class Comic
  attr_accessor :id, :image, :title, :alt

  def initialize(id, image, title, alt)
    self.id = id
    self.image = image.gsub('"', '').gsub('\\', '')
    self.title = title.gsub('"', '')
    self.alt = alt
  end
end
