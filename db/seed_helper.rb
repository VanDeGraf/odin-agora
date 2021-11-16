require 'faker'

OPTIONS = {
  user: {
    create: true,
    count: 10,
    create_avatar: false,
    create_friendship: true
  },
  post: {
    create: true,
    count: 10,
    create_likes: true,
    comment: {
      create: true,
      count: 20
    },
  },
  message: {
    create: true
  },
  faker_seed: 1,
  stub: {
    datetime: DateTime.current.prev_day,
    password: '123456',
    encrypted_password: User.new(:password => '123456').encrypted_password,
  }
}

def create_user_if_not_exists
  return unless DATA[:user][:id].empty?

  data = [
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      sex: Faker::Number.between(from: 0, to: 2),
      birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
      email: Faker::Internet.safe_email,
      encrypted_password: OPTIONS[:stub][:encrypted_password],
      confirmed_at: OPTIONS[:stub][:datetime],
      created_at: OPTIONS[:stub][:datetime],
      updated_at: OPTIONS[:stub][:datetime]
    }]
  DATA[:user] = table_inserts('users', data)
end

# @param msg [String]
def info_stage(msg)
  puts "\t#{msg}"
end

# @param msg [String]
def info_stage_item(msg)
  puts "\t\t#{msg}"
end

class UniqGenerator
  def initialize(generator_lambda, max_iterations = 1000)
    super()
    @generator_lambda = generator_lambda
    @values = []
    @max_iterations = max_iterations
  end

  def value
    result = @generator_lambda.call
    iteration = 0
    while @values.include?(result) do
      result = @generator_lambda.call
      iteration += 1
      raise StandardError.new('Cant found uniq value!') if iteration > @max_iterations
    end
    @values << result
    result
  end

  def reset
    @values = []
  end
end

# @param array1 [Array]
# @param array2 [Array]
# @return [Array<Array>]
def uniq_intersections(array1, array2, ordered = false, count_from: 0, count_to: 1000)
  return [] if array1.empty? || array2.empty?

  intersections = []
  if array1 == array2
    edge = ([array1.length, array2.length].min / 2).to_i
    count_from = [count_from, edge].min
    count_to = [count_to, edge].min
    arrays_equal = true
  else
    count_from = [count_from, array1.length - 1].min
    count_to = [count_to, array2.length - 1].min
    arrays_equal = false
  end

  Faker::Number.between(
    from: count_from,
    to: count_to
  ).times.map do
    value1, value2 = nil, nil
    while value1.nil? || value2.nil? ||
      (arrays_equal && value1.eql?(value2)) ||
      intersections.include?([value1, value2]) ||
      (!ordered && intersections.include?([value2, value1]))
      value1 = array1[Faker::Number.between(from: 0, to: array1.length - 1)]
      value2 = array2[Faker::Number.between(from: 0, to: array2.length - 1)]
    end
    intersections << [value1, value2]
  end
  intersections
end

# @param table_name [String]
# @param data [Array<Hash>]
# @param returning_key [String, Array]
# @return [Array, Hash]
def table_inserts(table_name, data, returning_key = 'id')
  return nil if data.nil? || data.empty?

  column_count = data.first.keys.length
  column_list = data.first.keys.join(',')
  values = data.map { |obj| obj.map { |_, value| value } }.flatten
  value_lists = data.length.times.map do
    "(#{column_count.times.map { '?' }.join(',')})"
  end.join(",\n")
  returning = if returning_key.is_a?(String)
                returning_type = :string
                "RETURNING #{returning_key}"
              elsif returning_key.is_a?(Array)
                returning_type = :array
                "RETURNING #{returning_key.join(',')}"
              else
                returning_type = :empty
                ''
              end
  sql = <<-SQL
INSERT INTO #{table_name} (#{column_list})
VALUES 
#{value_lists}
#{returning};
  SQL
  sql = ActiveRecord::Base.sanitize_sql_array([sql] + values)
  # @type [ActiveRecord::Result]
  result = ActiveRecord::Base.connection.exec_query(sql)
  case returning_type
  when :array, :string
    r = {}
    result.columns.each { |key| r[key.to_sym] = [] }
    result.rows.each do |row|
      result.columns.each_with_index do |column, i|
        r[column.to_sym] << row[i]
      end
    end
    r
  else
    result
  end
end
