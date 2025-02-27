from app.models.user_account import UserAccount, SuperAccount
from app.models.user_posts import Post
import json
import uuid

class PostRecord():
    """Banco de dados JSON para o recurso: Posts"""

    def __init__(self):
        self.__posts = []
        self.read()

    def read(self):
        try:
            with open("app/controllers/db/posts.json", "r") as fjson:
                post_data = json.load(fjson)
                valid_keys = ('id', 'title', 'content', 'username', 'email')
            self.__posts.clear
            self.__posts = [
                Post(**{k: v for k, v in post.items() if k in valid_keys})
                for post in post_data
            ]
        except FileNotFoundError:
            print('Não existem posts registrados!')

    def __write(self):
        try:
            with open("app/controllers/db/posts.json", "w") as fjson:
                post_data = [vars(post) for post in self.__posts]
                json.dump(post_data, fjson, ensure_ascii=False, indent=4)
                print('Posts gravados com sucesso!')
        except FileNotFoundError:
            print('Erro ao gravar os posts!')

    def create_post(self, title, content, username):
        current_user = self.getCurrentUserBySessionId()
        new_post = Post(str(uuid.uuid4()), title, content, username, current_user.email)
        self.__posts.append(new_post)
        self.__write()
        return new_post
    
    def get_posts(self):
        return self.__posts
        
    def accept_post(self, post_id, owner):
        for post in self.__posts:
            print(f"Verificando post: {post.id}")
            if post.id == post_id:
                print(f"Post encontrado. Atualizando owner para {owner}")
                post.owner = owner
                self.__write()
                return post
        return None

# ------------------------------------------------------------------------------

class UserRecord():
    """Banco de dados JSON para o recurso: Usuário"""

    def __init__(self):
        self.__allusers= {'user_accounts': [], 'super_accounts': []}
        self.__authenticated_users = {}
        self.read('user_accounts')
        self.read('super_accounts')


    def read(self, database):
        account_class = SuperAccount if (database == 'super_accounts') else UserAccount
        try:
            with open(f"app/controllers/db/{database}.json", "r") as fjson:
                user_d = json.load(fjson)
                for data in user_d:
                    if 'email' not in data:
                        data['email'] = 'default@example.com'
                self.__allusers[database] = [account_class(**data) for data in user_d]
        except FileNotFoundError:
            self.__allusers[database].append(account_class('Guest', '000000', 'default@example.com'))



    def __write(self,database):
        try:
            with open(f"app/controllers/db/{database}.json", "w") as fjson:
                user_data = [vars(user_account) for user_account in \
                self.__allusers[database]]
                json.dump(user_data, fjson)
                print(f'Arquivo gravado com sucesso (Usuário)!')
        except FileNotFoundError:
            print('O sistema não conseguiu gravar o arquivo (Usuário)!')



    def setUser(self,username,password,email):
        for account_type in ['user_accounts', 'super_accounts']:
            for user in self.__allusers[account_type]:
                if username == user.username:
                    user.password= password
                    print(f'O usuário {username} foi editado com sucesso.')
                    self.__write(account_type)
                    return username
        print('O método setUser foi chamado, porém sem sucesso.')
        return None


    def removeUser(self, user):
        for account_type in ['user_accounts', 'super_accounts']:
            if user in self.__allusers[account_type]:
                print(f'O usuário {"(super) " if account_type == "super_accounts" else ""}{user.username} foi encontrado no cadastro.')
                self.__allusers[account_type].remove(user)
                print(f'O usuário {"(super) " if account_type == "super_accounts" else ""}{user.username} foi removido do cadastro.')
                self.__write(account_type)
                return user.username
        print(f'O usuário {user.username} não foi identificado!')
        return None


    def book(self, username, password, email, permissions):
        account_type = 'super_accounts' if permissions else 'user_accounts'
        account_class = SuperAccount if permissions else UserAccount
        new_user = account_class(username, password, email, permissions) if permissions else account_class(username, password, email)
        self.__allusers[account_type].append(new_user)
        self.__write(account_type)
        return new_user.username


    def getUserAccounts(self):
        return self.__allusers['user_accounts']


    def getCurrentUser(self,session_id):
        if session_id in self.__authenticated_users:
            return self.__authenticated_users[session_id]
        else:
            return None


    def getAuthenticatedUsers(self):
        return self.__authenticated_users


    def checkUser(self, username, password):
        for account_type in ['user_accounts', 'super_accounts']:
            for user in self.__allusers[account_type]:
                if user.username == username and user.password == password:
                    session_id = str(uuid.uuid4())  # Gera um ID de sessão único
                    self.__authenticated_users[session_id] = user
                    return session_id  # Retorna o ID de sessão para o usuário
        return None


    def logout(self, session_id):
        if session_id in self.__authenticated_users:
            del self.__authenticated_users[session_id] # Remove o usuário logado
