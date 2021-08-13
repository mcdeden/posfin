<?php

namespace App;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laratrust\Traits\LaratrustUserTrait;

class User extends Authenticatable
{
    use Notifiable;
    use LaratrustUserTrait;

    protected $table='users';
    protected $fillable = ['name', 'email', 'password','bank_id','branch_id','pic_bank_id','insurance_id'];

    protected $hidden = ['password', 'remember_token'];

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }

    function bank_pic() {
        return $this->belongsTo('App\Models\MasterBank','pic_bank_id','id');
    }

    function branch() {
        return $this->belongsTo('App\Models\MasterBranch');
    }

    function insurance() {
        return $this->belongsTo('App\Models\MasterInsurances','insurance_id','id');
    }
}
