include BCrypt

User.create(name: 'luke', password_digest: Password.create('Jedi'), age: 23, email: 'luke@ga.com')
User.create(name: 'han', password_digest: Password.create('Falcon'), age: 25, email: 'han@ga.com')
User.create(name: 'leia', password_digest: Password.create('Alderaan'), age: 23, email: 'leia@ga.com')