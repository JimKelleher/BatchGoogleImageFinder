<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="ArtistGoogleImage.About" %>

<%@ Register src="AboutTable.ascx" tagname="AboutTable" tagprefix="uc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <link rel="icon"       type="image/x-icon" href="favicon.ico" />
    <link rel="stylesheet" type="text/css"     href="Site.css"    />
    <link rel="stylesheet" type="text/css"     href="AboutTable.css"    />

    <title>About Google Artist Image Search Utility</title>

</head>

<body>
    <form id="form1" runat="server">
        <div>
        </div>
        <uc1:AboutTable ID="AboutTable1" runat="server" />
    </form>
</body>
</html>
