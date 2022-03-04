---
title: Michael Abrash's Graphics Programming Black Book, Special Edition
author: Michael Abrash
date: '1997-07-01'
identifier:
- scheme: ISBN
  text: 1576101746
publisher: The Coriolis Group
category: 'Web and Software Development: Game Development,Web and Software Development:
  Graphics and Multimedia Development'
---

# Afterword

If you've followed me this far, you might agree that we've come through
some rough country. Still, I'm of the opinion that hard-won knowledge is
the best knowledge, not only because it sticks to you better, but also
because winning a hard race makes it easier to win the next one.

This is an unusual book in that sense: In addition to being a
compilation of much of what I know about fast computer graphics, it is a
journal recording some of the process by which I discovered and refined
that knowledge. I didn't just sit down one day to write this book—I
wrote it over a period of years and published its component parts in
many places. It is a journal of my successes and frustrations, with side
glances of my life as it happened along the way.

And there is yet another remarkable thing about this book: You, the
reader, helped me write it. Perhaps not you personally, but many people
who have read my articles and columns over the years sent me notes
asking me questions, suggesting improvements (occasionally by daring me
to beat them at the code performance game!) or sometimes just dumping
remarkable code into my lap. Where it seemed appropriate, I dropped in
the code and sometimes even the words of my correspondents, and the book
is much the richer for it.

Here and there, I learned things that had nothing at all to do with fast
graphics.

For example: I'm not a doomsayer who thinks American education lags
hopelessly behind the rest of the Western world, but now and then
something happens that makes me wonder. Some time back, I received a
letter from one Melvyn J. Lafitte requesting that I spend some time in
my columns describing fast 3-D animation techniques. Melvyn hoped that I
would be so kind as to discuss, among other things, hidden surface
removal and perspective projection, performed in real time, of course,
and preferably in Mode X. Sound familiar?

Melvyn shared with me a hidden surface approach that he had developed.
His technique involved defining polygon vertices in clockwise order, as
viewed from the visible side. Then, he explained, one can use the
cross-product equations found in any math book to determine which way
the perpendicular to the polygon is pointing. Better yet, he pointed
out, it's necessary to calculate only the Z component of the
perpendicular, and only the sign of the Z component need actually be
tested.

What Melvyn described is, of course, backface removal, a key
hidden-surface technique that I used heavily in X-Sharp. In general,
other hidden surface techniques must be used in conjunction with
backface removal, but backface removal is nonetheless important and
highly efficient. Simply put, Melvyn had devised for himself one of the
fundamental techniques of 3-D drawing.

Melvyn lives in Moens, France. At the time he wrote me, Melvyn was 17
years old. Try to imagine any American 17-year-old of your acquaintance
inventing backface removal. Try to imagine any teenager you know even
using the phrase "the cross-product equations found in any math book."
Not to mention that Melvyn was able to write a highly technical letter
in English; and if Melvyn's English was something less than flawless, it
was perfectly understandable, and, in my experience, vastly better than
an average, or even well-educated, American's French. Please understand,
I believe we Americans excel in a wide variety of ways, but I worry that
when it comes to math and foreign languages, we are becoming a nation of
*têtes de pomme de terre*.

Maybe I worry too much. If the glass is half empty, well, it's also half
full. Plainly, something I wrote inspired Melvyn to do something that is
wonderful, whether he realizes it or not. And it has been tremendously
gratifying to sense in the letters I have received the same feeling of
remarkably smart people going out there and doing amazing things just
for the sheer unadulterated fun of it.

I don't think I'm exaggerating too much (well, maybe a little) when I
say that this sort of fun is what I live for. I'm glad to see that so
many of you share that same passion.

Good luck. Thank you for your input, your code, and all your kind words.
Don't be afraid to attempt the impossible. Simply knowing what is
impossible is useful knowledge—and you may well find, in the wake of
some unexpected success, that not half of the things we call impossible
have any right at all to wear the label.

—Michael Abrash
