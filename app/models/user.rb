class User < ActiveRecord::Base
  has_secure_password
  has_many :comments
  has_many :transactions
  has_many :shouts
  has_attached_file :avatar,
                    :storage => :s3,
                    :s3_credentials => Proc.new{|a| a.instance.s3_credentials },
                    styles: { large: "300x300>", medium: "225x225>", small:"150x150" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  validates :username, uniqueness: true, length: { minimum: 1 }, presence: true

  after_initialize :set_defaults, unless: :persisted?   # The set_defaults will only work if the object is new
  after_create :create_initial_transaction


  def s3_credentials
    {:bucket => "bonecoin", :access_key_id => "AKIAJOQDU5Q67VG3MFNQ", :secret_access_key => "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", :s3_region => "us-east-1", :s3_host_name => "s3.us-east-1.amazonaws.com"}
  end

  def set_defaults #give the new user some coins to get started - should maybe just put this in the schema at some point but eh
    self.balance ||= 10
  end


  #
  def create_initial_transaction #spoof the transaction to make the coins look like they were gifted by god
    initial_transaction = Transaction.new
    initial_transaction.recipient_id = self.id
    initial_transaction.user_id = User.find_by(username: "God").id
    initial_transaction.amount = 10
    initial_transaction.note = "Welcome to BoneCoin, mortal! A gift, to get you started."
    initial_transaction.save
  end

end
