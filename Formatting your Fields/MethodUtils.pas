unit MethodUtils;


interface

uses System.Classes, System.SysUtils,
  System.Bindings.EvalProtocol;

type
  // Helper class to register LiveBindings Methods
  TMethodUtils = class
  private
    class procedure RegisterMethod(const AName: string; const AInvokable: IInvokable); overload;
    class procedure ValidateArgs(Args: TArray<IValue>; AExpectedCount: Integer); static;
  public
    // Register a method with 0 parameters
    class procedure RegisterMethod<TResult>(const AName: string; ACallback: TFunc<TResult>); overload;
    // Register a method with 1 parameter
    class procedure RegisterMethod<T1, TResult>(const AName: string; ACallback: TFunc<T1, TResult>); overload;
    // Register a method with 2 parameters
    class procedure RegisterMethod<T1, T2, TResult>(const AName: string; ACallback: TFunc<T1, T2, TResult>); overload;
    // Register a method with 3 parameters
    class procedure RegisterMethod<T1, T2, T3, TResult>(const AName: string; ACallback: TFunc<T1, T2, T3, TResult>); overload;
  end;

implementation

uses System.Bindings.Methods, System.Bindings.Consts,
  System.Rtti;

class procedure TMethodUtils.RegisterMethod(const AName: string;
  const AInvokable: IInvokable);
begin
  TBindingMethodsFactory.RegisterMethod(
    TMethodDescription.Create(
       AInvokable,
      AName,   // ID
      AName,   // Method name
      '',    // Unit name (design time support)
      True,  // Enabled
      '',    // Description (design time support)
      nil)); // Framework class
end;

class procedure TMethodUtils.ValidateArgs(Args: TArray<IValue>; AExpectedCount: Integer);
begin
  if Length(Args) <> AExpectedCount then
    raise EEvaluatorError.Create(Format(sUnexpectedArgCount, [AExpectedCount, Length(Args)]));
end;

class procedure TMethodUtils.RegisterMethod<TResult>(const AName: string;
  ACallback: TFunc<TResult>);
begin
  RegisterMethod(
    AName,
    MakeInvokable(
      function(Args: TArray<IValue>): IValue  // Anonymous method
      begin
        ValidateArgs(Args, 0);
        Exit(TValueWrapper.Create(TValue.From<TResult>(ACallback())))
      end
    )
  );
end;

class procedure TMethodUtils.RegisterMethod<T1, T2, T3, TResult>(const AName: string;
  ACallback: TFunc<T1, T2, T3, TResult>);
begin
  RegisterMethod(
    AName,
    MakeInvokable(
      function(Args: TArray<IValue>): IValue  // Anonymous method
      var
        LParam1: T1;
        LParam2: T2;
        LParam3: T3;
      begin
        ValidateArgs(Args, 3);
        if Args[0].GetValue.TryAsType<T1>(LParam1) and
          Args[1].GetValue.TryAsType<T2>(LParam2) and
          Args[2].GetValue.TryAsType<T3>(LParam3) then
            Exit(TValueWrapper.Create(TValue.From<TResult>(ACallback(LParam1, LParam2, LParam3))))
        else
          Exit(TValueWrapper.Create(nil));
      end
    )
  );
end;

class procedure TMethodUtils.RegisterMethod<T1, T2, TResult>(const AName: string;
  ACallback: TFunc<T1, T2, TResult>);
begin
  RegisterMethod(
    AName,
    MakeInvokable(
      function(Args: TArray<IValue>): IValue  // Anonymous method
      var
        LParam1: T1;
        LParam2: T2;
      begin
        ValidateArgs(Args, 2);
        if Args[0].GetValue.TryAsType<T1>(LParam1) and
          Args[1].GetValue.TryAsType<T2>(LParam2) then
            Exit(TValueWrapper.Create(TValue.From<TResult>(ACallback(LParam1, LParam2))))
        else
          Exit(TValueWrapper.Create(nil));
      end
    )
  );
end;

class procedure TMethodUtils.RegisterMethod<T1, TResult>(const AName: string;
  ACallback: TFunc<T1, TResult>);
begin
  RegisterMethod(
    AName,
    MakeInvokable(
      function(Args: TArray<IValue>): IValue  // Anonymous method
      var
        LParam1: T1;
      begin
        ValidateArgs(Args, 1);
        if Args[0].GetValue.TryAsType<T1>(LParam1) then
            Exit(TValueWrapper.Create(TValue.From<TResult>(ACallback(LParam1))))
        else
          Exit(TValueWrapper.Create(nil));
      end
    )
  );
end;

end.

