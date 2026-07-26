class Upload < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create
  before_save :set_original_name

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?

    loop do
      self.slug = Array.new(5) { [*'a'..'z', *'A'..'Z'].sample }.join
      break unless Upload.exists?(slug: slug)
    end
  end

  def set_original_name
    if file.attached? && name.blank?
      self.name = file.filename.to_s
    end
  end
end
