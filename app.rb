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
  results = db.execute("SELECT * FROM user WHERE Username = ?", username).first
  pwdigest = results["Pwdigest"]
  id = results["Id"]

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
    db.execute('INSERT INTO user (Username,Pwdigest) VALUES (?,?)', [username, password_digest])
    redirect('/')
  else
    "Lösenorden matchar inte"
  end
end

get('/sets') do
  db = SQLite3::Database.new("db/datab.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM sets")
  slim(:sets,locals:{sets:result})
end

get('/scarlet_violet') do
  db = SQLite3::Database.new("db/datab.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM cards")
  slim(:"set/scarlet_violet",locals:{cards:result})
end

get('/admin') do
  db = SQLite3::Database.new("db/datab.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM sets")
  slim(:"admin/index",locals:{sets:result})
end

post('/admin/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/datab.db")
  db.execute("DELETE FROM sets WHERE setid = ?", id)
  redirect("/admin")
end

get('/admin/new') do
  slim(:"admin/new")
end

post('/admin/new') do
  name = params[:name]
  setid = params[:setid].to_i
  gateway = params[:gateway]
  img = "sv#{setid}.png"
  p "DATA: #{name} OCH #{setid}"
  db = SQLite3::Database.new("db/datab.db")
  db.execute("INSERT INTO sets (name, setid, gateway, imagesource) VALUES (?,?,?,?)", [name, setid, gateway, img])
  redirect('/admin')
end
