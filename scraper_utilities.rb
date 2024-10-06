module ScraperUtilities
  module_function

  def print_capybara_tree(node, indent = 0)
    # Print the current node
    puts "#{' ' * indent}#{node.tag_name}#{node_attributes(node)}"

    # Handle shadow roots
    if node.evaluate_script("this.shadowRoot") != nil
      puts "#{' ' * (indent + 2)}[SHADOW-ROOT]"
      shadow_children = node.evaluate_script("Array.from(this.shadowRoot.children)")
      shadow_children.each do |child|
        print_capybara_tree(Capybara::Node::Element.new(node.session, child, node.base, node.query_scope), indent + 4)
      end
    end

    # Recursively print child nodes
    node.all(:xpath, './child::*', visible: :all).each do |child|
      print_capybara_tree(child, indent + 2)
    end
  end

  def node_attributes(node)
    attrs = []
    attrs << "##{node['id']}" if node['id']
    attrs << ".#{node['class'].split.join('.')}" if node['class']
    attrs.empty? ? '' : " #{attrs.join(' ')}"
  end

  def check_css_path(node, css_path)
    css_selectors = css_path.split(' ').reject { |s| s.match?(/^(html|body)/) }
    paths = [[node, []]]
    final_paths = []

    css_selectors.each_with_index do |selector, index|
      new_paths = []

      paths.each do |current_node, current_path|
        begin
          matched_nodes = retry_on_stale_element do |retry_count|
            if retry_count.even? && retry_count > 0
              current_node = recalculate_node(node, current_path)
              if current_node.nil?
                puts "Failed to recalculate node for path: #{current_path.join(' ')}. Skipping this path."
                break
              end
            end
            current_node&.all(:css, selector) || []
          end

          next if matched_nodes.empty?
          puts "Selector #{index.to_s.rjust(2)}: '#{selector}' matched #{matched_nodes.size} node(s)"

          matched_nodes.each do |matched_node|
            new_path = current_path + [selector]

            has_shadow_root = retry_on_stale_element do |retry_count|
              if retry_count.even? && retry_count > 0
                matched_node = recalculate_node(node, new_path)
                if matched_node.nil?
                  puts "Failed to recalculate node for shadow root check. Skipping this path."
                  break
                end
              end
              matched_node&.evaluate_script("!!(this.shadowRoot)") || false
            end

            if has_shadow_root
              shortened_path = shorten_path(current_node, new_path)
              final_paths << shortened_path
              shadow_root = retry_on_stale_element do |retry_count|
                if retry_count.even? && retry_count > 0
                  matched_node = recalculate_node(node, new_path)
                  if matched_node.nil?
                    puts "Failed to recalculate node for shadow root access. Skipping this path."
                    break
                  end
                end
                if (shadow_root = matched_node.evaluate_script("this.shadowRoot"))
                  Capybara::Node::Element.new(matched_node.session, shadow_root, matched_node.base, matched_node.query_scope)
                end
              end
              if shadow_root
                new_paths << [shadow_root, []]
                puts "Shadow DOM boundary detected after selector #{index}"
              else
                puts "Failed to access shadow root. Skipping this path."
              end
            else
              new_paths << [matched_node, new_path]
            end
          end
        rescue Capybara::ElementNotFound
          puts "Selector not found: #{selector}"
        end
      end

      paths = new_paths
      break if paths.empty?
    end

    final_paths += paths.map { |current_node, path| shorten_path(current_node, path) }

    optimized_paths = final_paths.map do |path|
      path.map { |selector| optimize_css_selector(selector, node) }.join(' ')
    end.uniq

    puts "Found optimized path: #{optimized_paths.inspect}"

    optimized_paths
  end

  def retry_on_stale_element(max_retries = 3)
    retries = 0
    begin
      result = yield retries
      return result if result
      raise Selenium::WebDriver::Error::StaleElementReferenceError if retries > 0
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      retries += 1
      if retries <= max_retries
        sleep(0.5 * retries) # Exponential backoff
        retry
      else
        return nil
      end
    end
  end

  def recalculate_node(root_node, path)
    current_node = root_node
    path.each do |selector|
      current_node = current_node.find(:css, selector)
    end
    current_node
  rescue Capybara::ElementNotFound
    nil
  end

  # The optimize_css_selector and shorten_path functions remain the same

  def optimize_css_selector(selector, node)
    original_matches = node.all(:css, selector)
    return selector if original_matches.empty?

    classes = selector.scan(/\.([\w-]+)/).flatten
    optimized_selector = selector.gsub(/\.[^.#\s]+/, '')

    classes.each do |class_name|
      test_selector = optimized_selector + '.' + class_name
      if node.all(:css, test_selector).size == original_matches.size
        optimized_selector = test_selector
      end
    end

    optimized_selector.strip
  end

  def shorten_path(node, path)
    original_matches = node.all(:css, path.join(' '))
    return path if original_matches.empty?

    (path.size - 1).downto(0).each do |i|
      shortened = path[i..-1]
      if node.all(:css, shortened.join(' ')).size == original_matches.size
        return shortened
      end
    end
    path
  end

  def find_all_nodes_with_paths(node, paths)
    return [] if paths.empty?

    begin
      result = node.all(:css, paths.first)
    rescue Capybara::ElementNotFound => e
      puts "Selector failed: #{selector}"
      puts "Error: #{e.message}"
    end

    if paths.size > 1
      matching_nodes = result
      result = []
      paths_tail = paths.drop(1)
      matching_nodes.each do |matching_node|
        shadow_node = Capybara::Node::Element.new(
          matching_node.session,
          matching_node.evaluate_script("this.shadowRoot"),
          matching_node.base,
          matching_node.query_scope
        )
        selected_nodes = find_all_nodes_with_paths(shadow_node, paths_tail)
        result.concat(selected_nodes)
      end
    end
    result
  end

  # Update the existing find_node_with_paths to use the new method
  def find_node_with_paths(node, paths)
    find_all_nodes_with_paths(node, paths).first
  end
end