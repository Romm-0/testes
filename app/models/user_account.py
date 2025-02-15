class UserAccount():

    def __init__(self, username, password, email):
        self.username= username
        self.password= password
        self.email= email

    def isAdmin(self):
        return False


class SuperAccount(UserAccount):

    def __init__(self, username, password, email, permissions):

        super().__init__(username, password, email)
        self.permissions= permissions
        if not permissions:
            self.permissions= ['user']

    def isAdmin(self):
        return True
