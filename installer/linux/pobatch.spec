Name:           pobatch
Version:        %{?version}
Release:        2%{?dist}
Summary:        PoBatch
License:        GPLv3
BuildArch:      x86_64
Requires:       gtk2

%define _build_name_fmt %%{name}-%%{version}.rpm

%description
PoBatch is an easy-to-use PO file editor for l10n workflows. It displays source strings and translations in a grid, allowing selection of columns or rows and bulk copy and paste operations. This makes it easy to quickly update translations within a PO file.

%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
cp -a "%{staging_dir}/." "%{buildroot}/"

%files -f %{_sourcedir}/pobatch.files
