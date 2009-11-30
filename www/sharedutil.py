

class FlexibleDefaultingDict(dict):
    """A specialized dictionary subclass which allows attribute
    access to the keys."""
    __attribute_values__ = []

    def __init__(self, attributes = None, **kwargs):
        for key, value in self.__attribute_values__:
            self[key] = value

        if attributes:
            self.update(attributes)
        if kwargs:
            self.update(kwargs)

    def __getattr__(self, attribute):
        try:
            return self[attribute]
        except KeyError:
            raise AttributeError("%s object has no attribute '%s'" % (self.__class__, attribute))


class DefaultingDict(FlexibleDefaultingDict):
    """A specialized dictionary subclass which allows attribute
    access to the keys, but only for a specific set of keys."""

    def __init__(self, attributes = None, **kwargs):
        FlexibleDefaultingDict.__init__(self, attributes, **kwargs)
        object.__setattr__(self, '__allowed_attributes__',
                [item[0] for item in self.__attribute_values__])

    def __setattr__(self, name, value):
        if name in self.__allowed_attributes__:
            self[name] = value
        else:
            raise AttributeError("%s object doesn't allow attribute '%s'" %
                    (self.__class__, name))


class LocationUpdateJSON(DefaultingDict):
    __attribute_values__ = [
                    ('display_name', None),
                    ('profile_image_url', None),
                    ('latitude', None),
                    ('longitude', None),
                    ('message', None),
                    ('message_time', None),
                    ('update_datetime', None),
            ]
