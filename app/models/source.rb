class Source < ActiveRecord::Base
  has_many :object_values

  def save
    File.open(name+'.yml','w') do |out|
      out.puts to_yaml
    end
  end
end
