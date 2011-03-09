require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MailboxerMailbox do
  
  before do
    @entity1 = Factory(:user)
    @entity2 = Factory(:user)
    @mail1 = @entity1.send_message(@entity2,"Body","Subject")
    @mail2 = @entity2.reply_to_all(@mail1,"Reply body 1")
    @mail3 = @entity1.reply_to_all(@mail2,"Reply body 2")
    @mail4 = @entity2.reply_to_all(@mail3,"Reply body 3")
    @message1 = @mail1.mailboxer_message
    @message4 = @mail4.mailboxer_message
    @conversation = @message1.mailboxer_conversation
  end  
  
  it "should return all conversations" do
    @conv2 = @entity1.send_message(@entity2,"Body","Subject").mailboxer_conversation
    @conv3 = @entity2.send_message(@entity1,"Body","Subject").mailboxer_conversation
    @conv4 =  @entity1.send_message(@entity2,"Body","Subject").mailboxer_conversation
    
    assert @entity1.mailbox.conversations
    
    @entity1.mailbox.conversations.to_a.count.should==4
        @entity1.mailbox.conversations.to_a.count(@conversation).should==1
        @entity1.mailbox.conversations.to_a.count(@conv2).should==1
        @entity1.mailbox.conversations.to_a.count(@conv3).should==1
        @entity1.mailbox.conversations.to_a.count(@conv4).should==1    
  end
  
  it "should return all mail" do 
    assert @entity1.mailbox.mail
    @entity1.mailbox.mail.count.should==4
    @entity1.mailbox.mail[0].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[0]
    @entity1.mailbox.mail[1].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[1]
    @entity1.mailbox.mail[2].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[2]
    @entity1.mailbox.mail[3].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[3]
    
    assert @entity2.mailbox.mail
    @entity2.mailbox.mail.count.should==4
    @entity2.mailbox.mail[0].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[0]
    @entity2.mailbox.mail[1].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[1]
    @entity2.mailbox.mail[2].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[2]
    @entity2.mailbox.mail[3].should==MailboxerMail.receiver(@entity2).conversation(@conversation)[3]    
  end
  
  it "should return sentbox" do
    assert @entity1.mailbox.inbox
    @entity1.mailbox.sentbox.count.should==2
    @entity1.mailbox.sentbox[0].should==@mail1
    @entity1.mailbox.sentbox[1].should==@mail3
    
    assert @entity2.mailbox.inbox
    @entity2.mailbox.sentbox.count.should==2
    @entity2.mailbox.sentbox[0].should==@mail2
    @entity2.mailbox.sentbox[1].should==@mail4
  end
  
  it "should return inbox" do
    assert @entity1.mailbox.inbox
    @entity1.mailbox.inbox.count.should==2
    @entity1.mailbox.inbox[0].should==MailboxerMail.receiver(@entity1).inbox.conversation(@conversation)[0]
    @entity1.mailbox.inbox[1].should==MailboxerMail.receiver(@entity1).inbox.conversation(@conversation)[1]
    
    assert @entity2.mailbox.inbox
    @entity2.mailbox.inbox.count.should==2
    @entity2.mailbox.inbox[0].should==MailboxerMail.receiver(@entity2).inbox.conversation(@conversation)[0]
    @entity2.mailbox.inbox[1].should==MailboxerMail.receiver(@entity2).inbox.conversation(@conversation)[1]
  end
  
  it "should return trashed mails" do 
    @entity1.mailbox.mail.move_to_trash
    
    assert @entity1.mailbox.trash
    @entity1.mailbox.trash.count.should==4
    @entity1.mailbox.trash[0].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[0]
    @entity1.mailbox.trash[1].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[1]
    @entity1.mailbox.trash[2].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[2]
    @entity1.mailbox.trash[3].should==MailboxerMail.receiver(@entity1).conversation(@conversation)[3]
    
    assert @entity2.mailbox.trash
    @entity2.mailbox.trash.count.should==0    
  end
  
  it "should delete trashed mails" do 
    @entity1.mailbox.mail.move_to_trash
    @entity1.mailbox.empty_trash
    
    assert @entity1.mailbox.trash
    @entity1.mailbox.trash.count.should==0    
    
    assert @entity2.mailbox.mail
    @entity2.mailbox.mail.count.should==4
    
    assert @entity2.mailbox.trash
    @entity2.mailbox.trash.count.should==0    
  end
  
end
