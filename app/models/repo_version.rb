class RepoVersion < ActiveRecord::Base
  belongs_to :group
  has_one :repository, through: :group

  before_create :generate_name
  after_create :create_tag

  private

  def tag_name
    "#{I18n.t('git.tag.' + type.underscore)}-#{Time.now.to_i}"
  end

  def generate_name
    self.name = tag_name
  end

  def create_tag
    repository.create_tag(name)
  end

end
