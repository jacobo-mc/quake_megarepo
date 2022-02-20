/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2006-2021 Kevin Shanahan

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#ifndef LIST_H
#define LIST_H

/*
 * Simple doubly linked list implementation.
 */

struct list_node {
    struct list_node *next;
    struct list_node *prev;
};

/* Iterate over each entry in the list */
#define list_for_each_entry(pos, head, member)				\
	for (pos = container_of((head)->next, typeof(*pos), member);	\
	     &pos->member != (head);					\
	     pos = container_of(pos->member.next, typeof(*pos), member))

/* Iterate over the list, safe for removal of entries */
#define list_for_each_entry_safe(pos, n, head, member)                  \
	for (pos = container_of((head)->next, typeof(*pos), member),	\
	     n = container_of(pos->member.next, typeof(*pos), member);	\
	     &pos->member != (head);					\
	     pos = n, n = container_of(n->member.next, typeof(*n), member))

#define LIST_HEAD_INIT(name) { &(name), &(name) }

static inline void
list_head_init(struct list_node *head)
{
    head->next = head->prev = head;
}

static inline void
list_add__(struct list_node *new,
	   struct list_node *prev,
	   struct list_node* next)
{
    next->prev = new;
    new->next = next;
    new->prev = prev;
    prev->next = new;
}

/* Add the new entry after the give list entry */
static inline void
list_add(struct list_node *new, struct list_node *head)
{
    list_add__(new, head, head->next);
}

/* Add the new entry before the given list entry (list is circular) */
static inline void
list_add_tail(struct list_node *new, struct list_node *head)
{
    list_add__(new, head->prev, head);
}

static inline void
list_del(struct list_node *entry)
{
    entry->next->prev = entry->prev;
    entry->prev->next = entry->next;
}

static inline qboolean
list_empty(struct list_node *head)
{
    return head->next == head;
}

#endif /* LIST_H */
