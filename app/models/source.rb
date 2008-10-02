class Source < ActiveRecord::Base
  has_many :object_values

  # useful to be able to have the source adapter code available for viewing in YAML files
  def save_to_yaml
    File.open(name+'.yml','w') do |out|
      out.puts to_yaml
    end
  end
end
