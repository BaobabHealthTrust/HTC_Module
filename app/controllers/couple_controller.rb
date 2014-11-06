class CoupleController < ApplicationController
  def status
     client = Client.find(params[:client_id])
     @partner = client.get_recent_partner
  end

  def testing
  end

  def counseling
      @client = Client.find(params[:client_id])
      @protocol = []
			CounselingQuestion.where("retired = 0 AND child = 0").order("position ASC").each {|protocol|
          @protocol << protocol
          ChildProtocol.where("parent_id = #{protocol.id}").each{|child|
             CounselingQuestion.where("question_id = #{child.protocol_id} AND retired = 0").order("position ASC").each{|x|
               @protocol << x
             }
          }
      }
      redirect_to client_path(@client.id) if @protocol.blank?
  end

  def assessment
  end

  def appointment
       spouse = RelationshipType.where("a_is_to_b = 'spouse/partner'").first.relationship_type_id
       @client = []
        Relationship.where("person_a = ? OR person_b = ? AND relationship = ?",
                          params[:client_id], params[:client_id], spouse).each {|p| 
                          @client << Client.find(p.person_a)
                          @client << Client.find(p.person_b)}

          
    
  end
end
