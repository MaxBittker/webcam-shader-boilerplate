
= module.exports $ \ (h s l a)
  cond (? a)
    + :hsla ":(" h :, s :% :, l :% :, a ":)"
    + :hsl  ":(" h :, s :% :, l :%      ":)"
