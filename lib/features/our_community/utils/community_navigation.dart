/// Popped when the user leaves or deletes a community so parent routes can exit too.
const communityLeftRouteResult = 'community_left';

bool communityRouteLeft(Object? result) => result == communityLeftRouteResult;
