# PowerShell.Modules
    <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserName">User Name:</asp:Label></td>
    <td>
    <asp:TextBox ID="UserName" runat="server" />
    <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName"
        ErrorMessage="User Name is required." ToolTip="User Name is required." ValidationGroup="prPFCounty"
        CssClass="forgotPasswordErrors" EnableClientScript="false" ForeColor="">*</asp:RequiredFieldValidator>
    </td>
</tr>
<tr>
    <td align="center" colspan="2" style="color: red">
    <asp:Literal ID="FailureText" runat="server" EnableViewState="False" />
    </td>
</tr>
<tr>
    <td align="right" colspan="2">
    <asp:Button ID="SubmitButton" runat="server" CommandName="Submit" Text="Submit" 
                ValidationGroup="prPFCounty" OnClick="SubmitButton_Click" />