function H = clean_hss(H)
  H.topnode = 1;
  H = clean_ric(H);
end

function H = clean_ric(H)
  if isempty(H.A11) && isempty(H.A22)
    H.leafnode = 1;
    H.Wl = []; H.Wr = []; H.Rl = []; H.Rr = [];
    H.ml = []; H.nl = []; H.mr = []; H.nr = [];
  else
    H.leafnode = 0;
    H.U = []; H.V = [];
    if ~isempty(H.A11)
      H.A11 = clean_ric(H.A11);
    end
    if ~isempty(H.A22)
      H.A22 = clean_ric(H.A22);
    end
  end
end