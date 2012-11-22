class Labeler

  require 'rubygems'
  require 'mechanize'
  require 'open-uri'
  require 'yaml'
  require 'csv'

  def initialize
    load_config
    @username = @config['username']
    @password = @config['password']
    @path = @config['path']
    home = 'http://ebay.com'
    @agent = Mechanize.new
    @home_page = @agent.get(home)
  end

  def get_labels
    if login
     get_label_data(get_selling_page)
    else
     puts "can not login"
    end 
  end
  
  def login
    sign_in_link = @home_page.link_with( :text => 'Sign in' )
    login_page = sign_in_link.click
    login_form = login_page.form_with( :name => 'SignInForm')
    login_form.userid = @username
    login_form.pass = @password
    @login_response =  login_form.submit
    @logged_in = @login_response.search('form#SignInForm').empty?
  end

  def get_selling_page
    main = @login_response.link_with( :text => 'Continue').click
    selling = main.link_with( :text => 'Sold' ).click
    sold = selling.link_with( :text => /Awaiting Shipment/).click
  end

  def get_label_data(sold)
    CSV.open("#{@config['file_path']}_#{Date.today}.csv", 'w') do |row|
      sold.links_with( :text => 'Print shipping label').each do |link|
        label = link.click
        row << get_items(label) + get_address(label)
        row << []
      end
    end
  end

  def get_items(label)
    qt_and_price = []
    label.search("span.odc_leftspan").each do |line|
      qt_and_price << line.children[0].children.text rescue nil
      qt_and_price << line.children[2].text.match(/(Qty: \d+)/)[0] rescue nil
    end
    qt_and_price.delete_if {|e| e == ''}
  end

  def get_address(label)
    address = []
    label.search("//*[@id='SHIP_TO_DISPLAY']/div[@class='shipfromtocomponent-wrapperDiv']/div/div/table/*/*/*/*/*/div[@id='addrrow']/*").children.each do |row|
      next if row.text == ""
      address << row.text
    end
    address
  end

  
  def load_config
    @config = YAML.load_file('./config.yml')
  end

end
