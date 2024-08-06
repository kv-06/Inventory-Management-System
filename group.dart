class Groups
{
  static int lastgrpid = 0;
  late  int grp_id;
  late int user_id;
  late String grp_name;

  Groups({
    required this.grp_id,
    required this.user_id,
    required this.grp_name,
  });

  Map<String, dynamic> toMap() {
    return {
      'grp_id': grp_id,
      'user_id': user_id,
      'grp_name': grp_name,
    };
  }

}