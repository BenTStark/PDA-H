INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES ({0}, COALESCE({1}, FALSE), {2}, {3}, {4});
