class Lesson < ApplicationRecord
  belongs_to :skill
  belongs_to :student, class_name: "User"

  def teacher
    self.skill.teacher
  end
end
