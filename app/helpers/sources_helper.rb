module SourcesHelper

    # logon to Sugar
  def sugar_logon(user,password)
    u = user
    p = Digest::MD5.hexdigest(password)
    ua = {"user_name" => u,"password" => p}
    wsdl = "http://yoursite.com/soap.php?wsdl"
    #create soap
    s = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    #uncomment this line for debugging. saves xml packets to files
    s.wiredump_file_base = "soapresult"
    #create session
    ss = s.login(ua,nil)
    #check for login errors
    if ss.error.number.to_i != 0
	#status message
	p "failed to login - #{ss.error.description}"
	#exit program
	return nil
    else
	#get id
	sid = ss['id']
	#get current user id
	uid = s.get_user_id(sid)
	#status message
	puts "logged in to session #{sid} as #{u} (#{uid}) "

        return sid
    end
  end

  def sugar_logout
    s.logout
  end

  # helper function to come up with the string used for the name_value_list
  # name_value_list =  [ { "name" => "name", "value" => "rhomobile" },
  #                     { "name" => "industry", "value" => "software" } ]
  def make_name_value_list(hash)
    if hash and hash.keys.size>0
      result="["
      hash.keys.each do |x|
        result << (" 'name' => '"+ x +"', 'value' => '" + hash[x] + "',")
      end
      result=result[0...result.size-1] # chop off the last comma
      result += "]"
    end
  end

end
