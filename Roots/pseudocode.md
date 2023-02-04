```c
struct Root {
    Root pred;
    Root next;
    CollisionBox platform;
    Position pos;
} 


move_pred(Root r, Position dir) 
{
    if (!peut_bouger_pred(r, dir))
        error()
    r = aller_au_premier(r)
    move_pred_aux(r, r.pos + dir)
}
move_pred_aux(Root r, Position new_pos)
{
    if(estVide(r))
    {
        return
    }
    Position old_pos = r.pos
    r.pos = new_pos
    move_pred_aux(r.next, old_pos)
}

peut_bouger_pred(Root r, Position dir) {
    r = aller_au_premier(r)
    peut_bouger_pred_aux(r, dir)
}
peut_bouger_pred_aux(Root r, Position dir)
{
    if(estVide(r))
    {
        return true
    }
    if(estPremier(r))
    {
        return estLibreRac(r.pos + dir)
            && estLibrePlat(r.pos + dir) 
            && peut_bouger_pred_aux(r.next, r.pos - r.next.pos)
    }
    if(r.platform != NULL)
    {
        return estLibrePlat(r.pos + dir) && peut_bouger_pred_aux(r.next, r.pos - r.next.pos)
    }
}


move_next(Root r, Position dir) 
{
    if (!peut_bouger_next(r, dir))
        error()
    r = aller_au_premier(r)
    move_pred_aux(r, r.pos + dir)
}
move_next_aux(Root r, Position new_pos)
{
    if(estVide(r))
    {
        return
    }
    Position old_pos = r.pos
    r.pos = new_pos
    move_pred_aux(r.next, old_pos)
}

peut_bouger_next(Root r, Position dir) {
    r = aller_au_dernier(r)
    peut_bouger_next_aux(r, dir)
}
peut_bouger_next_aux(Root r, Position dir)
{
    if(estVide(r))
    {
        return true
    }
    if(estDernier(r))
    {
        return estLibreRac(r.pos + dir) 
            && estLibrePlat(r.pos + dir)
            && peut_bouger_next_aux(r.next, r.pos - r.pred.pos)
    }
    if(r.platform != NULL)
    {
        return estLibrePlat(r.pos + dir) && peut_bouger_next_aux(r.next, r.pos - r.pred.pos)
    }
}

```