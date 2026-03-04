Message.destroy_all
Chat.destroy_all
Interview.destroy_all
User.destroy_all

puts "Création des utilisateurs..."

alice = User.create!(
  email: "alice@test.com",
  password: "password123"
)

bob = User.create!(
  email: "bob@test.com",
  password: "password123"
)

puts "2 utilisateurs créés"

puts "Création des interview sessions..."

session1 = Interview.create!(
  job_title: "Développeur Rails",
  job_description: "Entretien technique pour un poste de développeur Rails junior",
  status: "pending",
  user_id: alice.id,
  summary: nil
)

session2 = Interview.create!(
  job_title: "Développeur Front-end React",
  job_description: "Entretien pour un poste de développeur front-end spécialisé React",
  status: "completed",
  user_id: alice.id,
  summary: "Très bon candidat, à retenir"
)

session3 = Interview.create!(
  job_title: "Data Analyst",
  job_description: "Entretien pour un poste de data analyst junior",
  status: "pending",
  user_id: bob.id,
  summary: nil
)

session4 = Interview.create!(
  job_title: "DevOps Engineer",
  job_description: "Entretien pour un poste d'ingénieur DevOps",
  status: "completed",
  user_id: bob.id,
  summary: "Compétences solides sur Docker et Kubernetes"
)

puts "4 interview sessions créées"

puts "Création des chats..."

chat1 = Chat.create!(title: "Entretien Rails", user_id: alice.id, interview_id: session.id)
chat2 = Chat.create!(title: "Entretien React", user_id: alice.id, interview_id: session.id)
chat3 = Chat.create!(title: "Entretien Data", user_id: bob.id, interview_id: session.id)
chat4 = Chat.create!(title: "Entretien DevOps", user_id: bob.id, interview_id: session.id)

puts "4 chats créés"

puts "Ajout des messages..."

Chat.all.each do |chat|
  Message.create!(
    role: "system",
    content: "Bienvenue dans cet entretien : #{chat.title}",
    chat_id: chat.id
  )

  Message.create!(
    role: "user",
    content: "Salut, je suis prêt pour l'entretien.",
    chat_id: chat.id
  )

  Message.create!(
    role: "assistant",
    content: "Parfait, commençons.",
    chat_id: chat.id
  )

end

puts "Messages ajoutés"
puts "Seeds terminés !"