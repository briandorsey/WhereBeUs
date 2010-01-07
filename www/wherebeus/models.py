import logging

from google.appengine.ext import db
from .utils import get_rid_of_microseconds, iso_utc_string

class User(db.Model):
    display_name = db.StringProperty()
    profile_image_url = db.LinkProperty()
    large_profile_image_url = db.LinkProperty()
    service_url = db.LinkProperty() 
    message = db.StringProperty()
    message_time = db.DateTimeProperty()

class UserService(db.Model):
    KNOWN_SERVICE_TYPES = ['twitter', 'facebook']
    
    user = db.ReferenceProperty(User, collection_name = "services")
    display_name = db.StringProperty()
    profile_image_url = db.LinkProperty()
    large_profile_image_url = db.LinkProperty()
    service_url = db.LinkProperty()
    service_type = db.StringProperty()  # "twitter"
    id_on_service = db.IntegerProperty() # 12345
    friend_ids = db.ListProperty(int)   # [12345, 6789]
    
    @staticmethod
    def key_for_service_and_id(service_type, id_on_service):
        return 'us-%s-%s' % (service_type, str(id_on_service))
    
    @staticmethod
    def get_or_insert_for_service_and_id(service_type, id_on_service):
        if service_type not in UserService.KNOWN_SERVICE_TYPES:
            raise Exception("Invalid service_type")
        key_name = UserService.key_for_service_and_id(service_type, id_on_service)
        user_service = UserService.get_or_insert(key_name = key_name)
        user_service.service_type = service_type
        user_service.id_on_service = id_on_service
        if user_service.friend_ids is None:
            user_service.friend_ids = []
        return user_service
        
    def iter_friend_services(self):
        # TODO davepeck :: the performance here stinks. We need a different data model.
        key_names = [UserService.key_for_service_and_id(service_type = self.service_type, id_on_service = friend_id) for friend_id in self.friend_ids]
        user_services = UserService.get_by_key_name(key_names)
        for user_service in user_services:
            if user_service:
                yield user_service
    
    def iter_friend_users(self):
        for friend_service in self.iter_friend_services():
            yield friend_service.user
        
    def iter_friend_updates(self):
        for friend_user in self.iter_friend_users():
            if friend_user.location_updates:
                location_update = friend_user.location_updates[0]
                # Only provide an update if it is recent...
                if (datetime.datetime.now() - location_update.update_time) <= TIME_HORIZON:
                    update = {
                        "display_name": friend_user.display_name,
                        "profile_image_url": friend_user.profile_image_url,
                        "latitude": location_update.location.lat,
                        "longitude": location_update.location.lon,
                        "update_time": iso_utc_string(location_update.update_time),
                        "message": friend_user.message if friend_user.message else ""
                    }
                    yield update
                
    @staticmethod
    def iter_updates_for_user_services(user_services):
        seen = {}
        for user_service in user_services:
            for update in user_service.iter_friend_updates():
                key = (update["display_name"], update["profile_image_url"])
                if key not in seen:
                    seen[key] = True
                    yield update
                    
    @staticmethod
    def updates_for_user_services(user_services):
        return [update for update in UserService.iter_updates_for_user_services(user_services)]
        
class LocationUpdate(db.Model):
    user = db.ReferenceProperty(User, collection_name = "location_updates")
    location = db.GeoPtProperty()
    update_time = db.DateTimeProperty()
    horizontal_accuracy = db.FloatProperty()

