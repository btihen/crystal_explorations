# src/structs_n_records/user.cr
class User
  private getter name : String, email : String

  def initialize(@name, @email)
  end

  def to_s
    "#{name} <#{email}>"
  end

  def post_message(message : Message)
    puts message.to_s
  end
end
