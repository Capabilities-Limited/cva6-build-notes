#! /usr/bin/env sh

if [ -z ${notesdir+x} ]; then
  notesdir=$(pwd)
  echo ""
  echo "WARNING - \"\$notesdir\" not set. Defaulting to $notesdir."
  echo "WARNING - You can run the script again and explicitly set \$notesdir to the desired ABSOLUTE path to the notes directory."
  echo ""
fi

MD_SRCS=""
MD_SRCS+=" create-ubuntu-vm.md"
MD_SRCS+=" cva6-boot-linux.md"
MD_SRCS+=" cva6-vm-from-scratch-notes.md"
MD_SRCS+=" cva6-wsl-from-scratch-notes.md"
MD_SRCS+=" hello-world-verilator.md"
MD_SRCS+=" vivado-2020.1-ubuntu-install-notes.md"

RST_SRCS=""
RST_SRCS+="cva6-parameter-notes.rst"

wdir=$(pwd)
bdir=$(mktemp -d)

cd $bdir
echo "working from $bdir"

# toplevel adoc file
echo "preparing a toplevel document"
cat << EOF > top.adoc
:toc:
:toc-placement!:

:doctype: book
:title-logo-image: image:./img/CapLtdLogo.png[align=center]
:revdate: 18 December 2024

= SHIP Final Technical Report
:title-page:

<<<
toc::[]
<<<
EOF

echo "copy imgs"
cp -r $notesdir/img .

echo "gather individual documents"
function include_in_top() {
  # ensures a newline and page break at the end of the file
  echo "include::$1[]" >> top.adoc
  echo "[%always]" >> top.adoc
  echo "<<<" >> top.adoc
  echo "" >> top.adoc
}
for f in $MD_SRCS; do
  echo $f
  ff=${f%.*}.adoc
  # drop the first line of the md file (the cap ltd logo)
  tail -n +2 $notesdir/$f > $f
  # create the adoc document
  pandoc -f markdown -t asciidoc $f > $ff
  # add to top document
  include_in_top $ff
done
for f in $RST_SRCS; do
  echo $f
  ff=${f%.*}.adoc
  # bring original file
  cp $notesdir/$f $f
  # create the adoc document
  pandoc -f rst -t asciidoc $f > $ff
  # per file edit
  [ $f == "cva6-parameter-notes.rst" ] && \
    printf "== CVA6 parameterisation study\n%s\n" "$(cat $ff)" > $ff.fresh && \
    mv $ff.fresh $ff
  # add to top document
  include_in_top $ff
done

echo "build and retrieve pdf - $wdir/notes.pdf"
asciidoctor-pdf top.adoc && cp top.pdf $wdir/notes.pdf

cd $wdir
