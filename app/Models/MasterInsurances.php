<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterInsurances extends Model
{
    protected $table='master_insurances';

    public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];

    function map_insurance() {
        return $this->belongsTo('App\Models\MasterMapBankInsurance','id','insurance_id');
    }

    // public function user()
    // {
    //     return $this->hasMany('App\User');
    // }
}
