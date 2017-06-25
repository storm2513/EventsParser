class UpdateWorker
  include Sidekiq::Worker

  def perform(*args)
    puts "Starting update task"
	page_index = 1
	array = []
	doc = Nokogiri::HTML(open('https://events.dev.by/filter/all/tag?page=' + page_index.to_s))
	last_page = true if doc.xpath("//div[@class='next-posts']").text.size < 10
	while doc.xpath("//div[@class='next-posts']").text.size > 10 || last_page do
		events_size = doc.xpath("//div[@class='list-item-events list-more']//div[@class='item']").size
		0.upto(events_size - 1) do |i|
			event = {}
			event["title"] = doc.xpath("//a[@class='title']")[i].children.to_s.strip
			event["description"] = (doc.xpath("//div[@class='item-body left']//p//time")[i].children.to_s.delete!("\n").gsub("   ", " ") + doc.xpath("//div[@class='item-body left']//p")[i].children.last.to_s.gsub!("\n", " ")).gsub!("  ", " ").strip
			event["href"] = doc.xpath("//a[@class='title']")[i]["href"].to_s
			event["day"] = doc.xpath("//div[@class='item-date left']//h4")[i].children.to_s
			event["month"] = doc.xpath("//div[@class='item-date left']//strong//time")[i].children.to_s
			event["dayOfWeek"] = doc.xpath("//div[@class='item-date left']//span//time")[i].children.to_s
			content = Nokogiri::HTML(open('https://events.dev.by' + event["href"]))
			event_info = content.xpath("//div[@class='input']//div[@class='text']")
			event_info.search('.//img').remove
			event["content"] = event_info.to_s
			event["cost"] = content.xpath("//div[@class='bl']//div[@class='input']")[1].children.to_s.delete!("\n")
			unless content.xpath("//div[@class='input adress-events-map']").empty?
				place = content.xpath("//div[@class='input adress-events-map']").children[0].to_s.gsub!("\n", " ").strip
			else
				place = nil
			end
			event["place"] = place
			array << event
		end
		break if last_page
		page_index += 1
		doc = Nokogiri::HTML(open('https://events.dev.by/filter/all/tag?page=' + page_index.to_s))
		last_page = true if doc.xpath("//div[@class='next-posts']").text.size < 10
	end
	@current = Eventsbase.last.data
	if @current != array
		events = Eventsbase.new
		events.data = array
		events.save!
		puts "Events updated"
	else
		puts "Events were up to date"
	end
  end
end
