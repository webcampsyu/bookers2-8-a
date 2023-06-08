class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :books
  has_one_attached :profile_image
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  
  
  #フォローした関係のアソシエーション
  #foreign_keyは外部キー
  #has_many :relationships, class_name:"Relationship"では
  #Relationshipsテーブルのどちら(follower,followed)を参照すればいいかわからない
  #なので、fofeign_keyで参照先を指定する
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  
  
  #フォローされた関係のアソシエーション
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  #reverse_of_relationshipsはフォローした関係のアソシエーションと区別と付けるための記述
  
  #一覧画面で使う
   #has_many :架空のテーブル名, through: :中間テーブル名でテーブル同士が中間テーブルを
  #通じて繋がっていることを表現(followerテーブルとfollowedテーブルのつながり)
  #@user.架空のテーブル名と記述することでフォローorフォロワーの一覧を表示できる
  has_many :followings, through: :relationships, source: :followed
  #followingsは中間テーブル(relationships)を通じてfollowedモデルを取得できる
  
  has_many :followers, through: :reverse_of_relationships, source: :follower
  #followersは中間テーブルと通じてfollowerモデルを取得できる
  
 #Chatモデル,UserRoomモデル,Roomモデルとのアソシエーション
  has_many :chats
  has_many :user_rooms
  has_many :rooms, through: :user_rooms
  
  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 20 }
  validates :introduction, length: { maximum: 50 }
  
  
  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end
 
 
  #コントローラで使うメソッドを記述
  
  #フォローしたときの処理
  def follow(user_id)
    relationships.create(followed_id: user_id)
  end 
  
  #フォローを外すときの処理
  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end 
  
  #フォローしているか判定
  def following?(user)
    followings.include?(user)
  end 
  
  #検索方法分岐
  #nameは検索対象であるusersテーブル内のカラム名
  #検索フォームからsearchによって送られてきた内容を条件分岐させる
  #whereメソッドを用い、データベースから該当データを取得し、変数を代入
  #whereメソッドは、「テーブル内の条件に一致したレコードを配列の形で取得できるメソッド
  #whereのLIKE句を使ったあいまい検索の構文
  #モデルクラス.where("列名　LIKE ?"" "%値%) 
  def self.looks(search, word)
    #条件式1
    if search == "perfect_match"
    #処理1
    @user = User.where("name LIKE?","#{word}")
    #条件式2
    elsif search == "forward_match"
      #処理2
      @user = User.where("name LIKE?","#{word}%")
    #条件式3
    elsif search == "backward_match"
      #処理3
      @user = User.where("name LIKE?","%#{word}")
    #条件式4
    elseif search == "partial_match"
      #処理4
      @user = User.where("name LIKE?","%#{word}%")
    else 
      @user = User.all
    end 
  end 
  

end
