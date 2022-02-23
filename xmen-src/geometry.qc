// Just a handy proc for finding the angle between two vectors
// v1 and v2 must be in range 0 - 360
// answer is heading (Y) angle going from v1 to v2
float(float a1, float a2) angle_diff =
{
        if (a2 > a1) {
                if ((a2 - a1) > 180) {
                        return (a1 - (a2 - 360));
                }
                else {
                        return (a1 - a2);
                }
        }
        else {
                if ((a1 - a2) > 180) {
                        return (a1 - (a2 + 360));
                }
                else {
                        return (a1 - a2);
                }
        }
};

// Calculates and returns the reflection vector of the intersection
// of the vector "dir" with a "wall_normal" at position "org"
vector(vector org, vector dir, vector wall_normal) GetReflectionVect =
{
    local vector    first_wallpoint, second_wallpoint, first_linepoint, second_linepoint;
    // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
    //local float     wall_dist;

    first_linepoint = org - dir*4;
    traceline(first_linepoint, first_linepoint - wall_normal*8, TRUE, world);

    first_wallpoint = trace_endpos;

    second_wallpoint = org - (first_wallpoint - org);
    second_linepoint = second_wallpoint + wall_normal * 4;

    second_linepoint = normalize(second_linepoint - org);

    return second_linepoint;
};

float(float s_angle, float e_angle, float rate) MoveToAngle =
{
        local float     result;

        if ((s_angle > e_angle) &&
            ((s_angle - e_angle) > 180)) {
            e_angle = e_angle + 360;
        }
        else if ((e_angle > s_angle) &&
            ((e_angle - s_angle) > 180)) {
            s_angle = s_angle + 360;
        }

        if (s_angle > e_angle) {
                result = s_angle - rate*frametime;

                if (result < e_angle) result = e_angle;
        }
        else {
                result = s_angle + rate*frametime;

                if (result > e_angle) result = e_angle;
        }

        if (result >= 360) result = result - 360;
        if (result <    0) result = result + 360;

        return result;
};
