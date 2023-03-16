class Note {
  late String _source, _title, _description, _url, _publishedAt;

  Note( this._source, this._title, this._description, this._url,
      this._publishedAt);

  get source => _source;

  set source(value) {
    _source = value;
  }



  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['source'] = _source;
    map['title'] = _title;
    map['description'] = _description;
    map['url'] = _url;
    map['publishedAt'] = _publishedAt;

    return map;
  }

  // Extract a Note object from a Map object
  Note.fromMapObject(Map<String, dynamic> map) {
    this._source=map['source'];
    this._title=map['title'];
    this._description=map['description'];
    this._url=map['url'];
    this._publishedAt=map['publishedAt'];
  }

  get title => _title;

  set title(value) {
    _title = value;
  }

  get description => _description;

  set description(value) {
    _description = value;
  }

  get url => _url;

  set url(value) {
    _url = value;
  }

  get publishedAt => _publishedAt;

  set publishedAt(value) {
    _publishedAt = value;
  }
}
