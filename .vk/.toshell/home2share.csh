# Source this file from .vk directory
# WARNING: Perform below steps before running the script
#     1. Add below line in the .to_vk/.kprc.py
#          setenv VIMSHARE '/usr/share/vim'
#     2. Add below line in the /usr/share/vim/vimfiles/ftdetect/stp.vim
#          so /usr/share/vim/.vim/ftdetect/filetype.vim
cp .to_vk/.kprc.py /usr/share/vim/.kprc
cp .toshell/.cshrc /etc/profile.d/kp_cshrc.csh
cp .to_vk/.vim/ /usr/share/vim/ -rf
cd ../
cp .vk /usr/share/vim/ -rf

