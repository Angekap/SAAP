class Enunciation < ActiveRecord::Base
  require 'soft_destroy'
  include SoftDestroy
  belongs_to :crowd

  attr_accessor :current_user

  validates :end_at, timeliness: { on_or_after: lambda { Date.today } }
  validates :name, :description, presence: true

  has_many :groups, dependent: :destroy
  has_many :grouped_students, class_name: 'Student', through: :groups, source: :students
  has_many :students, through: :crowd
  has_many :attachments, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments, :allow_destroy => true, reject_if: proc { |attributes| attributes['document'].blank? }

  delegate :professor, :subject, to: :crowd

  after_save :log_activity

  def accepting_versions?
    end_at >= Time.now || accepts_after_deadline
  end

  def ungrouped_students
    students - grouped_students
  end

  def clone_for_crowd(crowd_id)
    cloned = self.class.new(name: self.name + ' - Clone', description: self.description, end_at: 1.day.from_now )
    cloned.clone_attachments(self)
    cloned.clone_groups(self) if crowd_id.to_i == self.crowd_id
    cloned
  end

  def to_s
    name
  end

  def clone_groups(enum)
    enum.groups.each do |g|
      group = Group.create(name: g.name, enunciation: self)
      g.students.map { |s| group.students << s }
    end
  end

  def clone_attachments(enum)
    enum.attachments.each do |a|
      Attachment.create!(document: a.document, attachable: self)
    end
  end

  private

  def log_activity
    if end_at_changed?
      ActivityLog.create!(item: self,
                          user: current_user,
                          action: 'enunciation_end_change',
                          serialized_object: changes[:end_at],
                          occurred_at: Time.current )
    end
  end


end
