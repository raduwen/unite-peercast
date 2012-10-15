
let s:save_cpo = &cpo
set cpo&vim

function! g:peercast.get_index()
  if !exists('g:peercast')
    let g:peercast = {}
    let g:peercast.yp_list = []
  endif
ruby << EOC
  Encoding.default_external='utf-8'
  def load_index(path)
    require 'open-uri'
    index = nil
    open(path) { |f| index = f.read }

    info = []

    index.each_line do |line|
    i = line.split('<>')
    info << {
      :channel_name   => i[0],
      :channel_id     => i[1],
      :host           => i[2],
      :contact_url    => i[3],
      :junle          => i[4],
      :detail         => i[5],
      :listener_count => i[6],
      :relay_count    => i[7],
      :bitlate        => i[8],
      :filetype       => i[9],
      :url_encoded    => i[14],
      :time           => i[15],
      :status         => i[16],
      :comment        => i[17]
    }
    end
    open(VIM.evaluate('g:peercast.tmpdir')+'/peercast.log', 'a+') do |f|
      f.puts "#{Time.now}: #{path}"
    end
    info
  end

  index = []
  VIM.evaluate('g:peercast.yp_list').each { |yp| index += load_index(yp+'index.txt') }
  open(VIM.evaluate('g:peercast.tmpdir')+"/yp_list.cache.dat", 'w') do |f|
    Marshal.dump(index, f)
  end
EOC
  return g:peercast.get_index_from_cache()
endfunction

function! g:peercast.get_index_from_cache()
ruby << EOC
  index = nil
  open(VIM.evaluate('g:peercast.tmpdir')+"/yp_list.cache.dat", 'r') do |f|
    index = Marshal.load(f)
  end
  VIM.command("let yp_info_list = []")
  index.each do |info|
    VIM.command("let info = {}")
    info.each do |key, value|
      VIM.command("let info['#{key}'] = '#{value}'")
    end
    VIM.command("call add(yp_info_list, info)")
  end
EOC
  return yp_info_list
endfunction

function! s:format_word(val)
  return printf("[%d/%d]%s[%s - %s] %s", a:val.listener_count, a:val.relay_count, a:val.channel_name, a:val.junle, a:val.detail, a:val.comment)
endfunction

function! unite#sources#peercast#define()
  return [s:source_peercast, s:source_peercast_bbs, s:source_peercast_update]
endfunction

let s:source_peercast = {
      \ 'name': 'peercast',
      \ 'description': 'pcyp and play',
      \ 'default_kind': 'guicmd',
      \ }

function! s:source_peercast.gather_candidates(args, context)
  let yp_info_list = g:peercast.get_index_from_cache()
  return map(yp_info_list, '{
        \ "word": s:format_word(v:val),
        \ "source": "peercast",
        \ "action__path": g:peercast.player,
        \ "action__args": [printf("http://%s/pls/%s?tip=%s", g:peercast.host, v:val.channel_id, v:val.host)],
        \ }')
endfunction

let s:source_peercast_bbs = {
      \ 'name': 'peercast/bbs',
      \ 'description': 'pcyp and view bbs',
      \ 'default_kind': 'guicmd',
      \ }

function! s:source_peercast_bbs.gather_candidates(args, context)
  let yp_info_list = g:peercast.get_index_from_cache()
  return map(yp_info_list, '{
        \ "word": s:format_word(v:val),
        \ "source": "peercast",
        \ "action__path": g:peercast.browser,
        \ "action__args": [v:val.contact_url],
        \ }')
endfunction

let s:source_peercast_update = {
      \ 'name': 'peercast/update',
      \ 'description': 'pcyp update info',
      \ 'default_kind': 'guicmd',
      \ }
function! s:source_peercast_update.gather_candidates(args, context)
  call g:peercast.get_index()
  return [{'word': "Updated!"}]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

