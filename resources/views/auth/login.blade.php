
@extends('layouts.blank')

@section('content')

<div class="card-box p-6">
        <h2 class="text-uppercase text-center pb-4">
            <a href="#" class="text-success">
                <span>
                    <img src="{{ asset('images/sifas.png') }}" style="width: 250px;height: 100px;margin-bottom: 30px;" class="m-b-10;" />
                </span>
            </a>
        </h2>



        <form class="" method="POST" action="{{ route('login') }}">
                @csrf
            <div class="form-group m-b-20 row">
                <div class="col-12">
                    <label for="emailaddress">Email address</label>
                    <input type="text" class="form-control" id="email" name="email" placeholder="email" required>
                </div>
            </div>

            <div class="form-group row m-b-20">
                <div class="col-12">
                    <label for="password">Password</label>
                    <input type="password" class="form-control" name="password" placeholder="Password" required>
                </div>
            </div>

            <div class="form-group row m-b-20">
                <div class="col-12">

                    <div class="checkbox checkbox-custom">
                        <input id="remember" type="checkbox" checked="">
                        <label for="remember">
                            Remember me
                        </label>
                    </div>

                </div>
            </div>

            <div class="form-group row text-center m-t-10">
                <div class="col-12">
                    <button class="btn btn-block btn-custom waves-effect waves-light" type="submit">Sign In</button>
                </div>
            </div>

        </form>

        <div class="row m-t-50">
            <div class="col-sm-12 text-center">
            </div>
        </div>

    </div>

@endsection
