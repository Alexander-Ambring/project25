require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

get('/') do
  slim(:start)
end

get('/login') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/datab.db')
  db.results_as_hash = true
  results = db.execute("SELECT * FROM user WHERE username = ?", username).first
  pwdigest = results["pwdigest"]
  id = results["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect("/sets")
  else
    "Fel lösenord"
  end
end

get('/register') do
  slim(:register)
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/datab.db')
    db.execute('INSERT INTO user (username,pwdigest) VALUES (?,?)', [username, password_digest])
    redirect('/')
  else
    "Lösenorden matchar inte"
  end
end

get('/sets') do
  slim(:sets)
end
