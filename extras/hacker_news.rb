# Script to auto post top posts on the front page of the HN with a comment

require 'net/http'

class HackerNews
  def self.get_hits
    uri = URI("https://hn.algolia.com/api/v1/search?tags=front_page")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    stories = json["hits"]
    selected_posts = stories.last(3)
    
    created_stories = self.post_story(selected_posts)
    self.post_comment(created_stories)
  end

  def self.post_story(selected_posts)
    created_stories = []
    hn_user = Rails.application.credentials.dig(:HN, :WRITER)
    bot = User.where(username: hn_user).first
  
    selected_posts.each do |s|
      story_hash = {}
      url = s["url"]
      title = s["title"]
      story = Story.create user: bot, title: title, url: url
      story_hash[:item] = s["objectID"]
      story_hash[:story_id] = story.id
      created_stories.push(story_hash)
    end
    created_stories
  end

  def self.post_comment(stories)
    puts stories
    hn_commenter = Rails.application.credentials.dig(:HN, :COMMENTER)

    stories.each do |story|
      next if story[:story_id].blank?
      id = self.get_first_comment(story[:item].to_s)
      uri = URI("https://hn.algolia.com/api/v1/items/"+id)
      response = Net::HTTP.get(uri)
      json = JSON.parse(response)
      next if json["author"] == "dang" # skip if its a mod post
      comment_html = json["text"]
      comment_html += "<a href=https://news.ycombinator.com/item?id=#{id}>original comment</a>"
      comment_md = ReverseMarkdown.convert comment_html
      puts comment_md
      bot = User.where(username: hn_commenter).first
      Comment.create user:bot, comment: comment_md, story_id: story[:story_id].to_i
    end
  end

  def self.get_first_comment(item)
    uri = URI("https://news.ycombinator.com/item?id="+item)
    response = Net::HTTP.get(uri)
    parsed_page = Nokogiri::HTML(response)
    first_comment_id = parsed_page.css("tr.athing")[1]["id"]
  end

end