datadir = '../Lab2&3_Com_2026_G2/';
h2p = load([datadir 'G2_Horn2probe_17p6.mat']); h2p = h2p.sdata;
l2p = load([datadir 'G2_Lens2probe.mat']);      l2p = l2p.sdata;
S21h = cell2mat(cellfun(@(z) z(:).', h2p.S21(:), 'uni', 0));
S21l = cell2mat(cellfun(@(z) z(:).', l2p.S21(:), 'uni', 0));
Ph = 10*log10(mean(abs(S21h).^2,2));
Pl = 10*log10(mean(abs(S21l).^2,2));
fprintf('H2P band-mean power vs x:\n');
for i=1:41, fprintf('  x=%5.0f mm  %7.2f dB\n', h2p.xpos_rel(i), Ph(i)); end
fprintf('L2P band-mean power vs x:\n');
for i=1:41, fprintf('  x=%5.0f mm  %7.2f dB\n', l2p.xpos_rel(i), Pl(i)); end
% where do edge spikes live in frequency?
[m,im] = max(abs(S21h(41,:))); fprintf('H2P x=200 max |S21|=%.1f dB at f=%.1f GHz\n',20*log10(m), (140e9+(im-1)*1e8)/1e9);
[m,im] = max(abs(S21h(1,:)));  fprintf('H2P x=0   max |S21|=%.1f dB at f=%.1f GHz\n',20*log10(m), (140e9+(im-1)*1e8)/1e9);
