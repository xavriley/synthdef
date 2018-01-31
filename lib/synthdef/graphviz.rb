module Graphviz
  def graphviz
    self[:synthdefs].each do |sdef|
    %Q{
      digraph synthdef {
        #{generate_node_info(sdef)}
        #{generate_node_connections(sdef)}
      }
    }.trim
    end
  end

  def generate_node_info(sdef)
    sdef[:ugens].each do |ug|
      case ug[:ugen_name]
      when "Control"
        style = ":rate"
      when "IR"
          style = "\" shape=invhouse style=\"rounded, dashed, filled, bold\" fillcolor=white fontcolor=black ]; "
      else
        style = "\" shape=invhouse style=\"rounded, filled, bold\" fillcolor=black fontcolor=white ]; "
      end
    end
  end

  def generate_node_connections(sdef)
  end
end
